# Database Handoff

The Database Developer/System Analyst owns this directory.

## Foundation deliverables

- Produce the initial ER diagram in `docs/diagrams/`.
- Identify entities, relationships, keys, constraints, and indexes.
- Add `schema.sql` for an empty database setup.
- Add `seed.sql` with safe sample data only.
- Document how to create and reset the local database.

## Initial entities

User, Address, Category, Product, Cart, CartItem, Order, OrderItem, Payment, Review, Seller, and SupportTicket.

The schema should be reviewed with the Backend Lead before the first JPA entities are created. Never commit real credentials or production data.
