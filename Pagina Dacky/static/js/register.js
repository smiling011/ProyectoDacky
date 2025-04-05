// register.js

document.addEventListener('DOMContentLoaded', () => {
    const registerForm = document.querySelector('.form-register');
    const alertaError = document.querySelector('.alerta-error');
    const alertaExito = document.querySelector('.alerta-exito');

    registerForm.addEventListener('submit', async (event) => {
        event.preventDefault();

        const userName = registerForm.userName.value.trim();
        const userLastName = registerForm.userLastName.value.trim(); // Asegúrate de tener este campo en tu formulario
        const userEmail = registerForm.userEmail.value.trim();
        const userPassword = registerForm.userPassword.value.trim();
        const userPhone = registerForm.userPhone.value.trim(); // Asegúrate de tener este campo
        const userAddress = registerForm.userAddress.value.trim(); // Asegúrate de tener este campo

        clearErrorStyles(registerForm);

        if (!userName || !userLastName || !userEmail || !userPassword || !userPhone || !userAddress) {
            showAlert(alertaError, "Todos los campos son obligatorios");
            highlightEmptyFields(registerForm, [userName, userLastName, userEmail, userPassword, userPhone, userAddress]);
            return;
        }

        if (!validateEmail(userEmail)) {
            showAlert(alertaError, "Por favor, ingresa un correo válido");
            registerForm.userEmail.classList.add('error');
            return;
        }

        try {
            const response = await fetch('/register', { // URL relativa
                method: 'POST',
                body: new FormData(registerForm) // Enviar FormData
            });

            const result = await response.json();

            if (response.status === 201) {
                showAlert(alertaExito, "Registro exitoso");
                setTimeout(() => {
                    window.location.href = '/login';
                }, 2000);
            } else if (response.status === 409) {
                showAlert(alertaError, result.message);
            } else {
                showAlert(alertaError, "Error al registrar el usuario");
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