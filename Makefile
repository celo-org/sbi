docker:
	docker pull $$(grep -oE 'FROM .+$$' Dockerfile | tr -d "FROM ")
	docker pull gcr.io/celo-testnet/sbi:latest
	docker build \
		--cache-from gcr.io/celo-testnet/sbi:latest \
		-t sbi .

release: docker
	docker tag sbi gcr.io/celo-testnet/sbi:latest 
	docker push gcr.io/celo-testnet/sbi:latest 
