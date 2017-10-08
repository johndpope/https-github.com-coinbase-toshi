psql -c "DROP DATABASE toshi_production;"
psql -c "CREATE DATABASE toshi_production;"
psql  toshi_production < dump_10-09-2017_15_16_30.sql