# Backend

```bash
iex -S mix

#Crear un nuevo usuario
alias Chat.User
user=User.add(user, :contacts, "name") 

#Iniciar nuevos procesos
alias Chat.Server
{:ok, chat} = Server.start_link("Name")
#Info process
state_data= :sys.get_state(chat)
state_data.user.name

```
# Frontend
