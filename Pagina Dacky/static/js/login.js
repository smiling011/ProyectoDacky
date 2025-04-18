// login.js

document.addEventListener('DOMContentLoaded', () => {
    const loginForm = document.querySelector('.form-login'); // Asegúrate que la clase sea correcta
    const alertaError = document.querySelector('.alerta-error'); // Asegúrate que exista
    const alertaExito = document.querySelector('.alerta-exito'); // Asegúrate que exista

    // Verificar si los elementos de alerta existen
    if (!alertaError || !alertaExito) {
        console.warn("Elementos de alerta no encontrados. Las alertas no funcionarán.");
    }
     if (!loginForm) {
        console.error("Formulario de login no encontrado.");
        return; // Salir si no hay formulario
    }


    loginForm.addEventListener('submit', async (event) => {
        event.preventDefault(); // Prevenir envío normal

        const userEmailInput = loginForm.querySelector("input[name='userEmail']");
        const userPasswordInput = loginForm.querySelector("input[name='userPassword']");

        // Verificar si los inputs existen
         if (!userEmailInput || !userPasswordInput) {
            console.error("Inputs de email o contraseña no encontrados en el formulario.");
            showAlert(alertaError, "Error interno del formulario.");
            return;
        }

        const userEmail = userEmailInput.value.trim();
        const userPassword = userPasswordInput.value.trim();

        clearErrorStyles(loginForm);
        hideAlerts(); // Ocultar alertas previas

        // Validaciones básicas
        if (!userEmail || !userPassword) {
            showAlert(alertaError, "Todos los campos son obligatorios");
            highlightEmptyFields(loginForm, [userEmail, userPassword]);
            return;
        }
        if (!validateEmail(userEmail)) {
            showAlert(alertaError, "Por favor, ingresa un correo válido");
            userEmailInput.classList.add('error'); // Aplicar estilo de error al campo
            return;
        }

        // Deshabilitar botón mientras se procesa (opcional)
        const submitButton = loginForm.querySelector('button[type="submit"]');
        if(submitButton) submitButton.disabled = true;


        try {
            const response = await fetch('/login', { // URL del backend
                method: 'POST',
                body: new FormData(loginForm) // Enviar datos del formulario
            });

            const result = await response.json(); // Leer respuesta JSON

            if (response.ok) { // Estado 200-299
                showAlert(alertaExito, result.message || "Inicio de sesión exitoso");
                // --- ¡CAMBIO PRINCIPAL AQUÍ! ---
                if (result.redirect_url) {
                    // Esperar un poco para que el usuario vea el mensaje de éxito
                    setTimeout(() => {
                       window.location.href = result.redirect_url; // Redirigir a la URL del backend
                    }, 1000); // Espera 1 segundo (ajustable)
                } else {
                    // Fallback si no hay URL (no debería pasar con el backend actual)
                    console.warn("No se recibió URL de redirección.");
                     showAlert(alertaError, "Redirección fallida.");
                     if(submitButton) submitButton.disabled = false; // Rehabilitar botón
                }
                // ---------------------------------
            } else {
                // Error (4xx, 5xx)
                showAlert(alertaError, result.message || `Error ${response.status}`);
                 if(submitButton) submitButton.disabled = false; // Rehabilitar botón
            }

        } catch (error) {
            console.error("Error en fetch:", error);
            showAlert(alertaError, "Error de conexión con el servidor.");
            if(submitButton) submitButton.disabled = false; // Rehabilitar botón
        }
    });

    // --- Funciones auxiliares (sin cambios mayores, pero mejoradas) ---
    function validateEmail(email) {
        const regex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
        return regex.test(String(email).toLowerCase());
    }

     function showAlert(alertElement, message) {
        if (!alertElement) return; // Salir si el elemento no existe
        alertElement.textContent = message;
        alertElement.style.display = 'block'; // Mostrar alerta
        alertElement.className = 'alerta'; // Clase base
        alertElement.classList.add(alertElement.classList.contains('alerta-error') ? 'alertaError' : 'alertaExito'); // Añadir clase específica

        // Ocultar después de un tiempo
        setTimeout(hideAlerts, 4000); // Ocultar después de 4 segundos
    }

    function hideAlerts() {
        if(alertaError) alertaError.style.display = 'none';
        if(alertaExito) alertaExito.style.display = 'none';
    }


    function highlightEmptyFields(form, fields) {
        const inputs = form.querySelectorAll('input[name="userEmail"], input[name="userPassword"]'); // Ser más específico
        inputs.forEach((input, index) => {
            if (!fields[index]) { // Si el valor correspondiente está vacío
                input.classList.add('error');
            }
        });
    }

    function clearErrorStyles(form) {
        const inputs = form.querySelectorAll('input.error');
        inputs.forEach(input => input.classList.remove('error'));
    }
});