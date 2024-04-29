({
  doInit: function(component, event, helper) {
      var targetDate = new Date("Jun 29, 2020 09:00:00").getTime();

      // Update the countdown every second
      var x = setInterval(function() {

        // Get today's date and time
        var now = new Date().getTime();

        // Find the distance between now and the count down date
        var distance = targetDate - now;

        // Time calculations for days, hours, minutes and seconds
        var days = Math.floor(distance / (1000 * 60 * 60 * 24));
        var hours = Math.floor((distance % (1000 * 60 * 60 * 24)) / (1000 * 60 * 60));
        var minutes = Math.floor((distance % (1000 * 60 * 60)) / (1000 * 60));
        var seconds = Math.floor((distance % (1000 * 60)) / 1000);

        // Display the result inside the HTML elements
        document.getElementById("days").innerHTML = days;
        document.getElementById("hours").innerHTML = hours;
        document.getElementById("minutes").innerHTML = minutes;
        document.getElementById("seconds").innerHTML = seconds;

        // If the count down is finished set all to 0
        if (distance < 0) {
          clearInterval(x);
          document.getElementById("days").innerHTML = "0";
          document.getElementById("hours").innerHTML = "0";
          document.getElementById("minutes").innerHTML = "0";
          document.getElementById("seconds").innerHTML = "0";
        }
      }, 1000);
  }
})