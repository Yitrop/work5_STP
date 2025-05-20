import pytest
from app import app

@pytest.fixture
def client():
    app.config['TESTING'] = True
    with app.test_client() as client:
        yield client

def test_time_route(client):
    response = client.get('/time')
    assert response.status_code == 200
    data = response.get_json()
    assert isinstance(data['time'], int)
    assert data['time'] > 0
