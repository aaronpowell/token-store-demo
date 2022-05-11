import { ChangeEvent, useEffect, useState } from "react";
import "./App.css";
import { Dropbox } from "dropbox";
import { DropboxSaveResponse } from "./DropboxSaveResponse";

const updateField =
  (updater: React.Dispatch<React.SetStateAction<string | undefined>>) =>
  (e: ChangeEvent<HTMLInputElement>) =>
    updater(e.target.value);

function App() {
  const [firstName, setFirstName] = useState<string | undefined>();
  const [lastName, setLastName] = useState<string | undefined>();
  const [email, setEmail] = useState<string | undefined>();
  const [phone, setPhone] = useState<string | undefined>();
  const [submitting, setSubmitting] = useState(false);
  const [dropboxResponse, setDropboxResponse] = useState<
    DropboxSaveResponse | undefined
  >();

  useEffect(() => {
    async function saveToDropbox() {
      const accessToken = ""; // this will be obtained from Token Store

      const dropbox = new Dropbox({ accessToken });

      const contents = `${firstName},${lastName},${email},${phone}`;
      const path = `submissions/${+new Date()}.csv`;

      const response = await dropbox.filesUpload({
        path,
        contents,
      });
      if (response.status !== 200) {
        setDropboxResponse({
          error: true,
          message: "Failed to upload to dropbox",
        });
        return;
      }

      setDropboxResponse({
        error: false,
        message: "Details have been saved. Start again?",
      });
    }

    if (!submitting) {
      return;
    }

    saveToDropbox();
  }, [submitting, firstName, lastName, email, phone]);

  if (dropboxResponse) {
    return <Completed dropboxResponse={dropboxResponse} />;
  }

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
