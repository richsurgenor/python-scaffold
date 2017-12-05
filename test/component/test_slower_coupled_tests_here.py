import time


class TestSlowTestsSuite(object):
    def test_something(self):
        time.sleep(1)
        assert True
