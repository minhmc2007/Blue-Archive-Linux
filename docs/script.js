const themeSwitcher = document.getElementById('theme-switcher');
const navToggle = document.getElementById('nav-toggle');
const navLinks = document.getElementById('nav-links');

themeSwitcher.addEventListener('click', () => {
    document.body.classList.toggle('dark-mode');
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