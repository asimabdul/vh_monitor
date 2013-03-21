function getStatus() {
  $.get("/status", function(data){
    $(".status-box").css("color", data.ci);
    if (data.ci == "blue") {
      blink(".project-name");
    }
  })
}

function blink(selector){
  $(selector).fadeOut('slow', function(){
    $(this).fadeIn('slow', function(){
      blink(this);
    });
  });
}

$(document).ready(function(){
  setInterval(getStatus, 4000);
})