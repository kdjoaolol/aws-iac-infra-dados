# Creditos pelo script: Professor Carlos Barbosa (linkedin.com/in/carlosbtech)

import os
import sys
import pymysql
from faker import Faker
from datetime import datetime
from faker_vehicle import VehicleProvider
from faker_airtravel import AirTravelProvider
from faker_credit_score import CreditScore

username = os.getenv("DB_USERNAME")
password = os.getenv("DB_PASSWORD")
host = os.getenv("DB_INSTANCE_ADDRESS")
port = os.getenv("DB_PORT")
database = os.getenv("DB_NAME")

try:
    conn = pymysql.connect(host=host, user=username, passwd=password, db=database, connect_timeout=5)
except pymysql.MySQLError as e:
    sys.exit()

def populate_mysql(event, context):

    faker = Faker()
    faker.add_provider(CreditScore)
    faker.add_provider(VehicleProvider)
    faker.add_provider(AirTravelProvider)

    with conn.cursor() as cur:
        cur.execute("""
         CREATE TABLE IF NOT EXISTS `customers` (
        `id` int NOT NULL AUTO_INCREMENT,
        `nome` text,
        `sexo` text,
        `endereco` text,
        `telefone` text,
        `email` text,
        `foto` text,
        `nascimento` date DEFAULT NULL,
        `profissao` text,
        `dt_update` timestamp NULL DEFAULT NULL,
        PRIMARY KEY (`id`)
        )
        """)

        cur.execute("""
        CREATE TABLE IF NOT EXISTS `credit_score` (
        `id` int NOT NULL AUTO_INCREMENT,
        `customer_id` int NOT NULL,
        `nome` text,
        `provedor` text,
        `credit_score` text,
        `dt_update` timestamp NULL DEFAULT NULL,
        PRIMARY KEY (`id`)
        )
        """)

        cur.execute("""
        CREATE TABLE IF NOT EXISTS `flight` (
        `id` int NOT NULL AUTO_INCREMENT,
        `customer_id` int NOT NULL,
        `aeroporto` text,
        `linha_aerea` text,
        `cod_iata` text,
        `dt_update` timestamp NULL DEFAULT NULL,
        PRIMARY KEY (`id`)
        )
        """)

        cur.execute("""
        CREATE TABLE IF NOT EXISTS `vehicle` (
        `id` int NOT NULL AUTO_INCREMENT,
        `customer_id` int NOT NULL,
        `ano_modelo` text,
        `modelo` text,
        `fabricante` text,
        `ano_veiculo` int DEFAULT NULL,
        `categoria` text,
        `dt_update` timestamp NULL DEFAULT NULL,
        PRIMARY KEY (`id`)
        )
        """)

        for i in range(1000):
            nome         = faker.name()
            customer_id  = faker.random_int()
            sexo         = faker.lexify(text='?', letters='MF')
            endereco     = faker.address() 
            telefone     = faker.phone_number() 
            email        = faker.safe_email() 
            foto         = faker.image_url() 
            nascimento   = faker.date_of_birth() 
            profissao    = faker.job() 
            provedor     = faker.credit_score_provider() 
            credit_score = faker.credit_score()
            ano_modelo   = faker.vehicle_year_make_model()
            modelo       = faker.vehicle_make_model() 
            fabricante   = faker.vehicle_make()
            ano_veiculo  = faker.vehicle_year() 
            categoria    = faker.vehicle_category() 
            aeroporto    = faker.airport_name()
            linha_aerea  = faker.airline()
            cod_iata     = faker.airport_iata()
            dt_update    = datetime.now() 

            customers_query = f"insert into customers ( nome, sexo, endereco, telefone, email, foto, nascimento, profissao, dt_update) values('{nome}', '{sexo}', '{endereco}', '{telefone}', '{email}', '{foto}', '{nascimento}', '{profissao}', '{dt_update}')"
            credit_query = f"insert into credit_score ( customer_id, nome, provedor, credit_score, dt_update) values('{customer_id}', '{nome}', '{provedor}', '{credit_score}', '{dt_update}')"
            vehicle_query = f"insert into vehicle ( customer_id, ano_modelo, modelo, fabricante, ano_veiculo, categoria, dt_update) values('{customer_id}', '{ano_modelo}', '{modelo}', '{fabricante}', '{ano_veiculo}', '{categoria}','{dt_update}')"
            flight_query = f"insert into flight ( customer_id, aeroporto, linha_aerea, cod_iata, dt_update) values('{customer_id}', '{aeroporto}', '{linha_aerea}', '{cod_iata}', '{dt_update}')"

            try:
                cur.execute(flight_query)
                conn.commit()
            except:
                print(f"Error writing flight row with the following values('{customer_id}', '{aeroporto}', '{linha_aerea}', '{cod_iata}', '{dt_update}')")
            
            try:
                cur.execute(customers_query)
                conn.commit()
            except:
                print(f"Error writing customer row with the following values('{nome}', '{sexo}', '{endereco}', '{telefone}', '{email}', '{foto}', '{nascimento}', '{profissao}', '{dt_update}')")

            try:
                cur.execute(credit_query)
                conn.commit()
            except:
                print(f"Error writing credit row with the following values('{customer_id}', '{nome}', '{provedor}', '{credit_score}', '{dt_update}')")

            try:
                cur.execute(vehicle_query)
                conn.commit()
            except:
                print(f"Error writing vehicle row with the following values('{customer_id}', '{ano_modelo}', '{modelo}', '{fabricante}', '{ano_veiculo}', '{categoria}','{dt_update}')")
    return "Finished creating Databases and writing rows"