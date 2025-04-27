let SessionStorage = {
  mounted() {
    const storedCode = sessionStorage.getItem("quiz_code");
     if (storedCode) {
      console.log("item")
       this.pushEvent("client_quiz_code", { quiz_code: storedCode });
     } else {
      const quizCode = this.el.dataset.quizCode;
      if (quizCode) {
        sessionStorage.setItem("quiz_code", quizCode);
        this.pushEvent("client_quiz_code", { quiz_code: quizCode });
      }
     }     
  }
};

export default SessionStorage;
