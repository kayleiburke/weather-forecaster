// Disable the submit button on the weather form after the user submits it
// in order to prevent multiple submissions while the form is being processed
document.addEventListener("DOMContentLoaded", function () {
    const form = document.getElementById("weather-form");
    const submitBtn = document.getElementById("submit-btn");

    if (form && submitBtn) {
        form.addEventListener("submit", function () {
            submitBtn.disabled = true;
            submitBtn.innerText = "Loading...";
        });
    }
});