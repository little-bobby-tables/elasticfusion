# Elasticfusion

Elasticfusion provides additional functionality on top of [*elasticsearch-rails*](https://github.com/elastic/elasticsearch-rails).

It includes:
* a keyword-based case-insensitive search engine supporting boolean expressions
(conjunction, disjunction, negation) and field queries (range);
* background jobs to carry out index updates.

It was written with a specific use case in mind and as such places a 
number of restrictions on the allowed use of Elasticsearch.
For instance, partial updates are not supported, and `_source` field
in general is encouraged to be disabled.

### Requirements

* Rails 5
* Elasticsearch 5

### Setup

1. Place your index definitions in *app/indexes* directory.

2. Drop `Elasticfusion.load_index_definitions` in *app/models/application_record.rb* 
(or any autoloaded file, really).

3. Add `indexing` queue to your Active Job backend.

### Usage examples

Elasticfusion was written specifically for [fanuniverse](https://www.github.com/little-bobby-tables/fanuniverse).
Refer to it for real-world usage examples.

### Aknowledgements

This gem was largely inspired by search handling in *booru-on-rails* ([Derpibooru](https://www.derpibooru.org)).
