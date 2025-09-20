const themeSwitcher = document.getElementById('theme-switcher');
const navToggle = document.getElementById('nav-toggle');
const navLinks = document.getElementById('nav-links');

// Function to apply theme based on preference
const applyTheme = (theme) => {
    if (theme === 'dark') {
        document.body.classList.add('dark-mode');
    } else {
        document.body.classList.remove('dark-mode');
    }
};

// Check for saved theme preference
const savedTheme = localStorage.getItem('theme');
const prefersDark = window.matchMedia('(prefers-color-scheme: dark)');

if (savedTheme) {
    applyTheme(savedTheme);
} else {
    applyTheme(prefersDark.matches ? 'dark' : 'light');
}

// Listen for theme preference changes
prefersDark.addEventListener('change', (e) => {
    if (!localStorage.getItem('theme')) {
        applyTheme(e.matches ? 'dark' : 'light');
    }
});

// Theme switcher button event
themeSwitcher.addEventListener('click', () => {
    const newTheme = document.body.classList.contains('dark-mode') ? 'light' : 'dark';
    localStorage.setItem('theme', newTheme);
    applyTheme(newTheme);
});

navToggle.addEventListener('click', () => {
    navLinks.classList.toggle('active');
    navToggle.classList.toggle('active');
});

// Animations on scroll
document.addEventListener("DOMContentLoaded", () => {
    const sections = document.querySelectorAll('section');

    const observerOptions = {
        root: null,
        rootMargin: '0px',
        threshold: 0.1
    };

    const observer = new IntersectionObserver((entries, observer) => {
        entries.forEach(entry => {
            if (entry.isIntersecting) {
                entry.target.classList.add('is-visible');
                observer.unobserve(entry.target);
            }
        });
    }, observerOptions);

    sections.forEach(section => {
        section.classList.add('fade-in-section');
        observer.observe(section);
    });
});
