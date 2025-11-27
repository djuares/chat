const user = {
  contacts: new Set(),
  chats: new Set(),
  notifications: new Set()
};

function render() {
  renderList("contacts-list", user.contacts);
  renderList("chats-list", user.chats);
  renderList("notifications-list", user.notifications);
}

function renderList(id, set) {
  const ul = document.getElementById(id);
  ul.innerHTML = "";
  set.forEach(item => {
    const li = document.createElement("li");
    li.textContent = item;
    ul.appendChild(li);
  });
}

function addContact() {
  const input = document.getElementById("contact-input");
  if (input.value.trim() !== "") {
    user.contacts.add(input.value.trim());
    input.value = "";
    render();
  }
}

function addChat() {
  const input = document.getElementById("chat-input");
  if (input.value.trim() !== "") {
    user.chats.add(input.value.trim());
    input.value = "";
    render();
  }
}

function addNotification() {
  const input = document.getElementById("notification-input");
  if (input.value.trim() !== "") {
    user.notifications.add(input.value.trim());
    input.value = "";
    render();
  }
}

render();
