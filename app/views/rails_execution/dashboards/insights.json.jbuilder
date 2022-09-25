json.labels @tasks_by_week.keys.map { |year, week| Date.commercial(year, week, 1).strftime('Week: %d/%m') }
json.datasets [{
  label: 'Created tasks',
  data: @tasks_by_week.values,
  borderWidth: 1,
  borderColor: 'rgba(255, 99, 132, 1)',
  backgroundColor: 'rgba(255, 99, 132, 0.2)',
}]
