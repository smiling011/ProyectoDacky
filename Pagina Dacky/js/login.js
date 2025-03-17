document.addEventListener('DOMContentLoaded', () => {
    const loginForm = document.querySelector('.form-login');
    const alertaError = document.querySelector('.alerta-error');
    const alertaExito = document.querySelector('.alerta-exito');

    loginForm.addEventListener('submit', (event) => {
        event.preventDefault();

        const userEmail = loginForm.userPassword.value.trim();
        const userPassword = loginForm.userPassword.value.trim();

    
        clearErrorStyles(loginForm);

        // Validaciones
        if (!userEmail || !userPassword) {
            showAlert(alertaError, "Todos los campos son obligatorios");
            highlightEmptyFields(loginForm, [userEmail, userPassword]);
            return;
        }

        if (!validateEmail(userEmail)) {
            showAlert(alertaError, "Por favor, ingresa un correo válido");
            loginForm.userPassword.classList.add('error');
            return;
        }

        showAlert(alertaExito, "Inicio de sesión exitoso");

        console.log({ userEmail, userPassword });
    });

    // correo 
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

    // campos vacios
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
