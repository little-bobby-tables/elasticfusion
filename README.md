# Elasticfusion

Elasticfusion provides additional functionality on top of [*elasticsearch-rails*](https://github.com/elastic/elasticsearch-rails).

It includes:
* a keyword-based search language supporting boolean expressions
(conjunction, disjunction, negation) and field queries (range);
* background jobs to carry out index updates;
* test extensions.

It was written with a specific use case in mind and as such places a 
number of restrictions on the allowed use of Elasticsearch.
For instance, partial updates are not supported, and `_source` field
in general is encouraged to be disabled.

### Requirements

* Rails 5
* Elasticsearch 5

### Aknowledgements

This gem was largely inspired by search handling in *booru-on-rails* ([Derpibooru](https://www.derpibooru.org)). 
In particular, I would like to express my gratitude to @liamwhite for his extensive work on the related code.
