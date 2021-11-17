docker:
	docker pull $$(grep -oE 'FROM .+$$' Dockerfile | tr -d "FROM ")
	docker pull us.gcr.io/celo-testnet/sbi:latest
	docker build \
		--cache-from us.gcr.io/celo-testnet/sbi:latest \
		-t sbi .

release: docker
	docker tag sbi us.gcr.io/celo-testnet/sbi:latest 
	docker push us.gcr.io/celo-testnet/sbi:latest 
