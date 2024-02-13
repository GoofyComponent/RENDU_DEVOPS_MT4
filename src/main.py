from pyspark.sql import SparkSession
from pyspark.sql.functions import desc
from pymongo import MongoClient
from utils import get_random_nationality, get_random_name

if __name__ == "__main__":
    spark = SparkSession.builder \
            .master(r'spark://spark-master:7077') \
            .appName('HelloWorld') \
            .getOrCreate()
            
            
    data_rows = []
    for _ in range(100):
        nationality = get_random_nationality()
        name = get_random_name()
        nationality_name = nationality[1]
        hello_world_translation = nationality[0]
        data_rows.append((name, nationality_name, hello_world_translation))

    data = spark.createDataFrame(data_rows, ["pseudo", "nationality", "hello_world"])
    
    data.show(10)
    pandas_df = data.toPandas()
    
    client = MongoClient('mongodb://admin:adminpassword@mongodb-container:27017/')
    db = client['test_database'] 
    collection = db['hello_world_collection']
    
    collection.insert_many(pandas_df.to_dict('records'))
    client.close()
    
    data_grouped = data.groupBy("nationality").count()
    data_grouped.show()
    
    data_grouped_ordered = data_grouped.orderBy(desc("count"))
    data_grouped_ordered.show()
            
    spark.stop()
