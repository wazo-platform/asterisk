Asterisk integration test
=========================

Requirements
------------

```
pip install -r requirements.txt
```

If you need to display the browser update config.ini
```
[browser]
visible = 1
```

Running the tests
-----------------

The tests can be launched with the following command

```
LETTUCE_CONFIG=<path/to/xivo-acceptance/config> lettuce features
```
