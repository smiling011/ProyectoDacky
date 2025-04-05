// login.js

document.addEventListener('DOMContentLoaded', () => {
    const loginForm = document.querySelector('.form-login');
    const alertaError = document.querySelector('.alerta-error');
    const alertaExito = document.querySelector('.alerta-exito');

    loginForm.addEventListener('submit', async (event) => {
        event.preventDefault();

        const userEmail = loginForm.querySelector("input[name='userEmail']").value.trim();
        const userPassword = loginForm.querySelector("input[name='userPassword']").value.trim();

        clearErrorStyles(loginForm);

        if (!userEmail || !userPassword) {
            showAlert(alertaError, "Todos los campos son obligatorios");
            highlightEmptyFields(loginForm, [userEmail, userPassword]);
            return;
        }

        if (!validateEmail(userEmail)) {
            showAlert(alertaError, "Por favor, ingresa un correo válido");
            loginForm.userEmail.classList.add('error');
            return;
        }

        try {
            const response = await fetch('/login', { // URL relativa
                method: 'POST',
                body: new FormData(loginForm) // Enviar FormData
            });

            const result = await response.json();

            if (response.status === 200) {
                showAlert(alertaExito, "Inicio de sesión exitoso");
                window.location.href = '/perfil'; // Redirigir a /perfil
            } else if (response.status === 401) {
                showAlert(alertaError, result.message);
            } else {
                showAlert(alertaError, "Error al iniciar sesión");
            }
        } catch (error) {
            showAlert(alertaError, "Error al conectar con el servidor");
        }
    });

    function validateEmail(email) {
        const regex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
        return regex.test(email);
    }

    function showAlert(alertElement, message) {
        alertElement.textContent = message;
        alertElement.classList.add(alertElement.classList.contains('alerta-error') ? 'alertaError' : 'alertaExito');
        setTimeout(() => {
            alertElement.textContent = "";
            alertElement.classList.remove('alertaError', 'alertaExito');
        }, 3000);
    }

    function highlightEmptyFields(form, fields) {
        const inputFields = form.querySelectorAll('input');
        inputFields.forEach((input, index) => {
            if (!fields[index]) {
                input.classList.add('error');
            }
        });
    }

    function clearErrorStyles(form) {
        const inputFields = form.querySelectorAll('input');
        inputFields.forEach(input => input.classList.remove('error'));
    }
});