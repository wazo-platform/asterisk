test-setup:
	docker pull wazopbx/wait
	if [ -n "$${REPO_URL}" ]; then \
		sed -e "s@RUN echo@RUN echo \"deb [trusted=yes] $${REPO_URL} ./\" > /etc/apt/sources.list.d/wazo-dev.list \&\& echo@" < ../Dockerfile > Dockerfile && \
		docker build -t wazopbx/asterisk . && \
		rm -f Dockerfile; \
	else \
		docker pull wazopbx/asterisk; \
	fi

test:
	py.test -x suite
