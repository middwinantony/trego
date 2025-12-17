document.addEventListener("DOMContentLoaded", () => {
  const intro = document.getElementById("intro-animation");
  const hero = document.getElementById("hero");

  setTimeout(() => {
    intro.classList.add("opacity-0");
  }, 1800);

  setTimeout(() => {
    intro.remove();
    hero.classList.remove("opacity-0", "translate-y-6")
  }, 2200);
});
