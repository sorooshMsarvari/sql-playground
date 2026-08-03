.PHONY: start start-ui stop status logs reset psql check check-all verify

start:
	./scripts/start.sh

start-ui:
	./scripts/start.sh --ui

stop:
	docker compose down

status:
	docker compose ps

logs:
	docker compose logs -f postgres

reset:
	./scripts/reset.sh

psql:
	docker compose exec postgres psql -U sql_student -d sql_playground

check:
	@test -n "$(SECTION)" || (echo "Usage: make check SECTION=03"; exit 2)
	./scripts/check-section.sh "$(SECTION)"

check-all:
	./scripts/check-all.sh

verify:
	./scripts/verify-playground.sh
