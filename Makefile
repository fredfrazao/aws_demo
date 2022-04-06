.DEFAULT_GOAL = help
.PHONY: help cleanup deploy gen-ssh-key
		
gen-ssh-key:
 ./scripts/create_ssh_key.sh

cleanup: 
./scripts/cleanup.sh

deploy:
./scripts/deploy.sh
