(() => {
  'use strict';

  const menuButton = document.querySelector('.menu-toggle');
  const navigation = document.querySelector('#primary-nav');
  const mobileQuery = window.matchMedia('(max-width: 640px)');

  function closeMenu() {
    menuButton.setAttribute('aria-expanded', 'false');
    menuButton.setAttribute('aria-label', 'Open navigation');
    navigation.classList.remove('is-open');
  }

  menuButton.addEventListener('click', () => {
    const open = menuButton.getAttribute('aria-expanded') !== 'true';
    menuButton.setAttribute('aria-expanded', String(open));
    menuButton.setAttribute('aria-label', open ? 'Close navigation' : 'Open navigation');
    navigation.classList.toggle('is-open', open);
  });

  navigation.addEventListener('click', (event) => {
    if (event.target.closest('a')) closeMenu();
  });

  document.addEventListener('click', (event) => {
    if (!event.target.closest('.header-inner')) closeMenu();
  });

  document.addEventListener('keydown', (event) => {
    if (event.key === 'Escape' && menuButton.getAttribute('aria-expanded') === 'true') {
      closeMenu();
      menuButton.focus();
    }
  });

  mobileQuery.addEventListener('change', closeMenu);

  const dialog = document.querySelector('.enquiry-dialog');
  const form = document.querySelector('#enquiry-form');
  const status = document.querySelector('#form-status');

  document.querySelectorAll('[data-contact-open]').forEach((button) => {
    button.addEventListener('click', () => {
      dialog.showModal();
      document.body.classList.add('dialog-open');
    });
  });

  document.querySelector('[data-contact-close]').addEventListener('click', () => dialog.close());
  dialog.addEventListener('close', () => document.body.classList.remove('dialog-open'));
  dialog.addEventListener('click', (event) => {
    if (event.target !== dialog) return;
    const bounds = dialog.getBoundingClientRect();
    if (event.clientX < bounds.left || event.clientX > bounds.right || event.clientY < bounds.top || event.clientY > bounds.bottom) {
      dialog.close();
    }
  });

  form.addEventListener('submit', (event) => {
    event.preventDefault();
    if (!form.reportValidity()) return;
    const values = new FormData(form);
    const name = values.get('name').trim();
    const email = values.get('email').trim();
    const service = values.get('service');
    const project = values.get('project').trim();
    if (!name || !project) {
      status.textContent = 'Please add your name and a few details about your project.';
      (!name ? form.elements.name : form.elements.project).focus();
      return;
    }
    const subject = `Project enquiry: ${service}`;
    const body = `Hello Harq Media,\n\n${project}\n\nInterested in: ${service}\n\nName: ${name}\nEmail: ${email}`;
    const emailLink = document.querySelector('.contact-email');
    const recipient = emailLink.getAttribute('href').replace(/^mailto:/, '');
    window.location.href = `mailto:${recipient}?subject=${encodeURIComponent(subject)}&body=${encodeURIComponent(body)}`;
    status.textContent = 'Your enquiry is ready in your email app. Please send it there to get in touch. If no email app opened, email hello@harqmedia.com directly.';
  });

  document.querySelector('#year').textContent = new Date().getFullYear();
})();
