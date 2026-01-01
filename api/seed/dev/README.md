# Development Database Seeding

This directory contains scripts for seeding the development database with initial data required for the application to function properly.

## Scripts

### `create-sabeq-user.js`

Creates the "sabeq" user in the database. This is a special user that is automatically added as a friend to all newly registered users.

**User Details:**
- ID: `60d18088076b0b7d53e5a35a`
- Username: `sabeq`
- Email: `sabeq@tanafaso.com`
- First Name: `سابق` (Arabic for "previous/former")

## How It Works

The seed scripts are automatically executed when running `docker-compose up` through the `mongo-seed` service. This service:

1. Waits for MongoDB to be ready (5 second delay)
2. Executes all scripts in this directory
3. Exits after completion (restart: "no")

## Manual Execution

If you need to manually run the seed scripts:

```bash
docker exec -i mongo mongosh tanafaso -u tanafaso-db-username -p tanafaso-db-password < seed/dev/create-sabeq-user.js
```

## Notes

- These scripts are designed for **development environments only**
- Production data should be managed separately
- The scripts are idempotent - running them multiple times will not create duplicates (they check if data already exists)
