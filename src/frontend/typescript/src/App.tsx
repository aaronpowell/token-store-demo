import { ChangeEvent, useState } from "react";
import "./App.css";

const updateField =
  (updater: React.Dispatch<React.SetStateAction<string | undefined>>) =>
  (e: ChangeEvent<HTMLInputElement>) =>
    updater(e.target.value);

function App() {
  const [firstName, setFirstName] = useState<string | undefined>(undefined);
  const [lastName, setLastName] = useState<string | undefined>(undefined);
  const [email, setEmail] = useState<string | undefined>(undefined);
  const [phone, setPhone] = useState<string | undefined>(undefined);
  const [submitting, setSubmitting] = useState(false);

  return (
    <div className="App">
      <header className="App-header">
        <h1>Contoso Lead Capture</h1>
        <form
          action=""
          onSubmit={(e) => (
            e.preventDefault(),
            setSubmitting(true),
            console.log({ firstName, lastName, email, phone })
          )}
        >
          <fieldset>
            <div>
              <label htmlFor="firstName">First name</label>
              <input
                type="text"
                name="firstName"
                id="firstName"
                placeholder="Aaron"
                value={firstName}
                onChange={updateField(setFirstName)}
              />
            </div>
            <div>
              <label htmlFor="lastName">Last name</label>
              <input
                type="text"
                name="lastName"
                id="lastName"
                placeholder="Powell"
                value={lastName}
                onChange={updateField(setLastName)}
              />
            </div>
          </fieldset>

          <fieldset>
            <div>
              <label htmlFor="email">Email</label>
              <input
                type="email"
                id="email"
                name="email"
                placeholder="foo@email.com"
                value={email}
                onChange={updateField(setEmail)}
              />
            </div>

            <div>
              <label htmlFor="phone">Phone</label>
              <input
                type="phone"
                id="phone"
                name="phone"
                placeholder="555-555-555"
                value={phone}
                onChange={updateField(setPhone)}
              />
            </div>
          </fieldset>

          <fieldset>
            <button
              type="submit"
              disabled={
                submitting || !firstName || !lastName || !email || !phone
              }
            >
              Submit
            </button>
          </fieldset>
        </form>
      </header>
    </div>
  );
}

export default App;
