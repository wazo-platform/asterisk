To run :

    docker run -v /config/asterisk/odbc:/etc/odbc/ -v /conf/xivo-confgend-client:/etc/xivo-confgend-client/ -p 5060:5060 -p 2000:2000 -p 5038:5038 -it xivo/asterisk bash
