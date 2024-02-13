import pytest
from pyspark.sql import SparkSession
from pymongo import MongoClient
from utils import get_random_nationality, get_random_name

@pytest.fixture(scope="session")    

def test_get_random_nationality():
    nationality = get_random_nationality()
    assert isinstance(nationality, tuple)
    assert len(nationality) == 2
    assert isinstance(nationality[0], str)
    assert isinstance(nationality[1], str)

def test_get_random_name():
    name = get_random_name()
    assert isinstance(name, str)