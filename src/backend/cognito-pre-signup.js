exports.handler = async (event) => {
    // Auto-confirm the user
    event.response.autoConfirmUser = true;

    // Set email as verified (optional, if you want to skip email verification entirely)
    // event.response.autoVerifyEmail = true;

    return event;
};
