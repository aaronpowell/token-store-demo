import type { DropboxSaveResponse } from "../DropboxSaveResponse";

export const Completed = ({
  dropboxResponse,
}: {
  dropboxResponse: DropboxSaveResponse;
}) => {
  if (dropboxResponse.error) {
    return (
      <div className="App">
        <header className="App-header">
          <h1>⚠️ {dropboxResponse.message} ⚠️</h1>
        </header>
      </div>
    );
  }

  return (
    <div className="App">
      <header className="App-header">
        <h1>{dropboxResponse.message}</h1>
        <button onClick={() => window.location.reload()}>Start again</button>
      </header>
    </div>
  );
};
