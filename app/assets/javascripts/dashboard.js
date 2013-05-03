function getStatus() {
  $.get("/status", function(data){
    for (var status in data.job_statuses) {
      status_div = $("." + data.job_statuses[status]['name']);
      status_div.removeClass('blue orange red green gray');
      status_div.addClass(data.job_statuses[status]['color']);

      status_div.find(".timestamp").text(data.job_statuses[status]['updated_at']);

      var branch_details = "(" + data.job_statuses[status]['branch'] +
          " by " + data.job_statuses[status]['author'] +
          " at <b>" + data.job_statuses[status]['formatted_deployed_at'] + "</b>)";
      status_div.find(".details").html(branch_details);

      $(".container .message").text(data.job_statuses[status]['message']);

      status_div.addClass(data.job_statuses[status]['priority']);
    }

    $(".container .message").html(data.message);
  })
}

function blink() {
  $(".status-box.attention").removeClass('blue orange red green gray');
  $(".status-box.attention.blink").addClass("red");
  $(".status-box.attention").toggleClass("blink");
}

$(document).ready(function(){
  setInterval(getStatus, 4000);
  setInterval(blink, 700);
  setInterval('window.location.reload()', 600000);
})