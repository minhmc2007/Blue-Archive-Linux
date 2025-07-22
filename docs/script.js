const themeSwitcher = document.getElementById('theme-switcher');

themeSwitcher.addEventListener('click', () => {
    document.body.classList.toggle('dark-mode');
});
