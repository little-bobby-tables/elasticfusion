# Load Elasticfusion index definitions from app/indexes directory.
Dir.glob(Rails.root.join('app', 'indexes', '*.rb'), &method(:require))
