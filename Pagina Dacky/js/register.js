// register.js

document.addEventListener('DOMContentLoaded', () => {
    const registerForm = document.querySelector('.form-register');
    const alertaError = document.querySelector('.alerta-error');
    const alertaExito = document.querySelector('.alerta-exito');

    registerForm.addEventListener('submit', async (event) => {
        event.preventDefault();

        const userName = registerForm.userName.value.trim();
        const userEmail = registerForm.userEmail.value.trim();
        const userPassword = registerForm.userPassword.value.trim();

        clearErrorStyles(registerForm);

        // Validaciones
        if (!userName || !userEmail || !userPassword) {
            showAlert(alertaError, "Todos los campos son obligatorios");
            highlightEmptyFields(registerForm, [userName, userEmail, userPassword]);
            return;
        }

        if (!validateEmail(userEmail)) {
            showAlert(alertaError, "Por favor, ingresa un correo válido");
            registerForm.userEmail.classList.add('error');
            return;
        }

        // Enviar datos al backend
        try {
            const response = await fetch('http://127.0.0.1:5000/register', {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({ name: userName, email: userEmail, password: userPassword })
            });
            
            const result = await response.json();
            
            if (result.success) {
                showAlert(alertaExito, "Registro exitoso");
                setTimeout(() => {
                    window.location.href = '/login';
                }, 2000);
            } else {
                showAlert(alertaError, result.message);
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
