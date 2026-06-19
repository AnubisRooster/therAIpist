import pytest


@pytest.mark.asyncio
async def test_visualization_empty(client):
    resp = await client.get("/graph-ui/nonexistent/visualization")
    assert resp.status_code == 200
    data = resp.json()
    assert data["nodes"] == []
    assert data["edges"] == []


@pytest.mark.asyncio
async def test_visualization_with_data(client):
    create_resp = await client.post("/sessions", json={"title": "Viz"})
    session_id = create_resp.json()["id"]

    n1 = await client.post("/graph/nodes", json={
        "type": "emotion", "label": "joy", "session_id": session_id,
    })
    n2 = await client.post("/graph/nodes", json={
        "type": "event", "label": "vacation", "session_id": session_id,
    })
    n1_id = n1.json()["id"]
    n2_id = n2.json()["id"]

    await client.post("/graph/edges", json={
        "source_id": n1_id, "target_id": n2_id, "relationship": "CAUSES",
        "session_id": session_id,
    })

    resp = await client.get(f"/graph-ui/{session_id}/visualization")
    assert resp.status_code == 200
    data = resp.json()
    assert len(data["nodes"]) == 2
    assert len(data["edges"]) == 1

    node_types = {n["type"] for n in data["nodes"]}
    assert "emotion" in node_types
    assert "event" in node_types

    for n in data["nodes"]:
        assert n["color"] is not None
        assert n["shape"] is not None
        assert n["size"] >= 10

    edge = data["edges"][0]
    assert edge["relationship"] == "CAUSES"
    assert edge["width"] >= 1


@pytest.mark.asyncio
async def test_visualization_colors_and_shapes(client):
    create_resp = await client.post("/sessions", json={"title": "Colors"})
    session_id = create_resp.json()["id"]

    types = ["person", "event", "emotion", "belief", "theme"]
    for t in types:
        await client.post("/graph/nodes", json={
            "type": t, "label": f"test_{t}", "session_id": session_id,
        })

    resp = await client.get(f"/graph-ui/{session_id}/visualization")
    data = resp.json()
    assert len(data["nodes"]) == 5

    colors = {n["type"]: n["color"] for n in data["nodes"]}
    shapes = {n["type"]: n["shape"] for n in data["nodes"]}
    assert all(c is not None for c in colors.values())
    assert colors["person"] != colors["emotion"]
    assert all(s is not None for s in shapes.values())


@pytest.mark.asyncio
async def test_stats_empty(client):
    resp = await client.get("/graph-ui/nonexistent/stats")
    assert resp.status_code == 200
    data = resp.json()
    assert data["total_nodes"] == 0


@pytest.mark.asyncio
async def test_stats_with_data(client):
    create_resp = await client.post("/sessions", json={"title": "Stats"})
    session_id = create_resp.json()["id"]

    n1 = await client.post("/graph/nodes", json={
        "type": "emotion", "label": "fear", "session_id": session_id,
    })
    n2 = await client.post("/graph/nodes", json={
        "type": "event", "label": "speaking", "session_id": session_id,
    })
    n3 = await client.post("/graph/nodes", json={
        "type": "theme", "label": "avoidance", "session_id": session_id,
    })
    await client.post("/graph/edges", json={
        "source_id": n2.json()["id"], "target_id": n1.json()["id"],
        "relationship": "TRIGGERS", "session_id": session_id,
    })

    resp = await client.get(f"/graph-ui/{session_id}/stats")
    assert resp.status_code == 200
    data = resp.json()
    assert data["total_nodes"] == 3
    assert data["total_edges"] == 1
    assert data["density"] > 0
    assert data["nodes_by_type"]["emotion"] == 1
    assert data["edges_by_relationship"]["TRIGGERS"] == 1
    assert data["isolated_nodes"] == 1


@pytest.mark.asyncio
async def test_timeline_empty(client):
    resp = await client.get("/graph-ui/nonexistent/timeline")
    assert resp.status_code == 200
    data = resp.json()
    assert data["timeline"] == []


@pytest.mark.asyncio
async def test_timeline_with_data(client):
    create_resp = await client.post("/sessions", json={"title": "Timeline"})
    session_id = create_resp.json()["id"]

    n1 = await client.post("/graph/nodes", json={
        "type": "emotion", "label": "anger", "session_id": session_id,
    })
    n2 = await client.post("/graph/nodes", json={
        "type": "event", "label": "conflict", "session_id": session_id,
    })
    await client.post("/graph/edges", json={
        "source_id": n2.json()["id"], "target_id": n1.json()["id"],
        "relationship": "TRIGGERS", "session_id": session_id,
    })

    resp = await client.get(f"/graph-ui/{session_id}/timeline")
    assert resp.status_code == 200
    data = resp.json()
    assert len(data["timeline"]) == 3

    types = [e["type"] for e in data["timeline"]]
    assert types.count("node_added") == 2
    assert types.count("edge_added") == 1

    for event in data["timeline"]:
        assert event["timestamp"] is not None


@pytest.mark.asyncio
async def test_stats_degree_distribution(client):
    create_resp = await client.post("/sessions", json={"title": "Degrees"})
    session_id = create_resp.json()["id"]

    n1 = await client.post("/graph/nodes", json={
        "type": "person", "label": "self", "session_id": session_id,
    })
    n2 = await client.post("/graph/nodes", json={
        "type": "emotion", "label": "happy", "session_id": session_id,
    })
    n3 = await client.post("/graph/nodes", json={
        "type": "event", "label": "event", "session_id": session_id,
    })

    await client.post("/graph/edges", json={
        "source_id": n1.json()["id"], "target_id": n2.json()["id"],
        "relationship": "ASSOCIATED_WITH", "session_id": session_id,
    })
    await client.post("/graph/edges", json={
        "source_id": n1.json()["id"], "target_id": n3.json()["id"],
        "relationship": "ASSOCIATED_WITH", "session_id": session_id,
    })

    resp = await client.get(f"/graph-ui/{session_id}/stats")
    data = resp.json()
    assert "degree_distribution" in data
    assert data["degree_distribution"].get("2", 0) >= 1
