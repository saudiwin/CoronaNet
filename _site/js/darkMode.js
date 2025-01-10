function detectColorScheme() {
    var theme = "light";    //default to light

    //local storage is used to override OS theme settings
    if (localStorage.getItem("theme")) {
        if (localStorage.getItem("theme") === "dark") {
            theme = "dark";
        }
    } else if (!window.matchMedia) {
        //matchMedia method not supported
        return false;
    } else if (window.matchMedia("(prefers-color-scheme: dark)").matches) {
        //OS theme setting detected as dark
        theme = "dark";
    }

    //dark theme preferred, set document with a `data-theme` attribute
    if (theme === "dark") {
        document.documentElement.setAttribute("data-theme", "dark");
        document.getElementById("particles-js").style.backgroundColor = "#232B32";
        var twitter = document.getElementsByClassName("twitter-timeline");
        if (twitter.length > 0) {
            twitter[0].setAttribute("data-theme", "dark");
        }
    }
}
detectColorScheme();
    
const toggleSwitch = document.querySelector('#theme-switch input[type="checkbox"]');

//function that changes the theme, and sets a localStorage variable to track the theme between page loads
function switchTheme(e) {
        if (e.target.checked) {
            localStorage.setItem('theme', 'dark');
            document.documentElement.setAttribute('data-theme', 'dark');
            // change header colour
            document.getElementById("particles-js").style.backgroundColor = "#232B32";
            // change Twitter colour
            var twitter = document.getElementsByClassName("twitter-timeline");
            if (twitter.length > 0) {
                twitter[0].setAttribute("data-theme", "dark");
            }
            // change table backgrounds
            $.fn.dataTable.tables({ api: true }).ajax.reload();
        } else {
            localStorage.setItem('theme', 'light');
            document.documentElement.setAttribute('data-theme', 'light');
            // change header colour
            document.getElementById("particles-js").style.backgroundColor = "#f4f4f4";
            // change Twitter colour
            var twitter = document.getElementsByClassName("twitter-timeline");
            if (twitter.length > 0) {
                twitter[0].setAttribute("data-theme", "light");
            }
            // change table backgrounds
            $.fn.dataTable.tables({ api: true }).ajax.reload();
        }    
    }

    //listener for changing themes
    toggleSwitch.addEventListener('change', switchTheme, false);

    //pre-check the dark-theme checkbox if dark-theme is set
    if (document.documentElement.getAttribute("data-theme") == "dark") {
        toggleSwitch.checked = true;
    } else {
        toggleSwitch.checked = false;
    }