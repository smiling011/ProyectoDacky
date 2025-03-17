import pymysql
pymysql.install_as_MySQLdb()

class Config:
    SQLALCHEMY_DATABASE_URI = 'mysql+pymysql://root:12345@localhost/dacky'
    SQLALCHEMY_TRACK_MODIFICATIONS = False
