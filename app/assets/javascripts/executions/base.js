//= require_tree ./ace.1.32.5
//= require_tree .

document.addEventListener("DOMContentLoaded", function() {
  flatpickr("input[type=datetime-local]", {
    minDate: "today",
    enableTime: true,
    dateFormat: "Y-m-d H:i",
    time_24hr: true,
  });
});
