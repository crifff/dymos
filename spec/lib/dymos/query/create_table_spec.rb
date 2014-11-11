Dymos::Client.create_table(
  name: 'test_create_table',
  attributes: {id: 'S', type: 'S'},
  keys: {id: 'HASH', type: 'RANGE'},
  throughput: [1, 1],
  gsl: [{type: Range, projection_type: "ALL", throughput: [1, 1]}]
)