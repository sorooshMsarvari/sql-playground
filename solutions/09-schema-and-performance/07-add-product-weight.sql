ALTER TABLE shop.products
ADD COLUMN weight_grams integer CHECK (weight_grams > 0);

