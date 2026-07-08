// ═══════════════════════════════════════════════════════
// ABC Technologies — main.js
// Scroll animations, sticky nav, active link, form UX
// ═══════════════════════════════════════════════════════

document.addEventListener('DOMContentLoaded', () => {

  // ── 1. Active nav link based on current page ─────────
  const path = window.location.pathname.split('/').pop() || 'index.html';
  document.querySelectorAll('nav a').forEach(link => {
    if (link.getAttribute('href') === path) {
      link.classList.add('active');
    }
  });

  // ── 2. Sticky header — add .scrolled class on scroll ─
  const header = document.getElementById('site-header');
  const onScroll = () => {
    if (header) {
      header.classList.toggle('scrolled', window.scrollY > 20);
    }
  };
  window.addEventListener('scroll', onScroll, { passive: true });

  // ── 3. Intersection Observer — reveal cards on scroll ─
  const revealTargets = document.querySelectorAll(
    '.card, .service-card, .job-card, .gallery-item, .timeline-item'
  );

  if (revealTargets.length > 0) {
    const observer = new IntersectionObserver((entries) => {
      entries.forEach(entry => {
        if (entry.isIntersecting) {
          entry.target.classList.add('visible');
          observer.unobserve(entry.target);
        }
      });
    }, { threshold: 0.1, rootMargin: '0px 0px -40px 0px' });

    revealTargets.forEach(el => observer.observe(el));
  }

  // ── 4. Contact form — smooth submit with success msg ─
  const form = document.getElementById('contact-form');
  const successMsg = document.getElementById('form-success');

  if (form) {
    form.addEventListener('submit', (e) => {
      e.preventDefault();
      const btn = form.querySelector('button[type="submit"]');
      if (btn) {
        btn.textContent = 'Sending…';
        btn.disabled = true;
      }
      // Simulate send
      setTimeout(() => {
        if (successMsg) {
          successMsg.style.display = 'block';
        }
        form.reset();
        if (btn) {
          btn.textContent = 'Send Message →';
          btn.disabled = false;
        }
        // Hide after 5s
        setTimeout(() => {
          if (successMsg) successMsg.style.display = 'none';
        }, 5000);
      }, 800);
    });
  }

  // ── 5. Animate hero stat numbers (count-up) ─────────
  const stats = document.querySelectorAll('.stat-number');
  if (stats.length > 0) {
    const countUp = (el) => {
      const target = el.textContent;
      // Only animate pure numeric targets
      const numMatch = target.match(/^(\d+)/);
      if (!numMatch) return;
      const end = parseInt(numMatch[1], 10);
      const suffix = target.replace(numMatch[1], '');
      let start = 0;
      const duration = 1500;
      const step = end / (duration / 16);
      const timer = setInterval(() => {
        start = Math.min(start + step, end);
        el.textContent = Math.round(start) + suffix;
        if (start >= end) clearInterval(timer);
      }, 16);
    };

    const heroObserver = new IntersectionObserver((entries) => {
      entries.forEach(entry => {
        if (entry.isIntersecting) {
          countUp(entry.target);
          heroObserver.unobserve(entry.target);
        }
      });
    }, { threshold: 0.5 });

    stats.forEach(s => heroObserver.observe(s));
  }

});
