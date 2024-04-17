"use client";
import { Card, CircularProgress, IconButton } from "@mui/material";
import VerifiedIcon from "@mui/icons-material/Verified";
import { useQuery } from "react-query";
import Button from "@mui/material/Button";
import { useSession } from "next-auth/react";
import { useUsers } from "@/store/user_store";
function Admin() {
  const { data: session } = useSession();

  const { data: users, isLoading } = useUsers(
    session?.user.userToStudies[0].study.id || ""
  );

  const sendLink = (name: string, email: string) => {
    fetch("/postcovid-dashboard/api/mail", {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
      },
      body: JSON.stringify({
        email: email,
        name: name,
      }),
    })
      .then((response) => {})
      .then((error) => {
        console.log(error);
      });
  };

  return isLoading ? (
    <div className="w-full h-full flex items-center justify-center">
      <CircularProgress />
    </div>
  ) : (
    <div className="w-full flex flex-col items-center justify-center">
      <h1 className="pb-20">Administration Panel</h1>

      <div className="w-full lg:w-3/5">
        <Card sx={{ padding: 2 }}>
          <h2 className="pb-7 lg:pb-10">Verification requested</h2>
          <div className="flex flex-col mb-2">
            <div className="flex flex-row">
              <div className="w-[25%] lg:w-1/3 font-bold ml-2">Name</div>
              <div className="w-[25%] lg:w-1/3 font-bold">Email</div>
            </div>
            {users &&
              users.map((user: any) => (
                <div
                  key={user.email}
                  className="flex flex-row m-2 items-center"
                >
                  <div className="w-[25%] lg:w-1/3 text-sm">{user.name}</div>
                  <div className="w-[25%] lg:w-1/3 text-sm">{user.email}</div>
                  <div className="w-3/6 flex items-center text-sm justify-end">
                    <span className="mr-2 text-sm">Verify</span>
                    <Button
                      sx={{ fontSize: 10 }}
                      variant="contained"
                      onClick={(event: any) => {
                        event.target.disabled = true;
                        event.target.style.backgroundColor = "grey";
                        sendLink(user.name, user.email);
                      }}
                    >
                      Send Link
                    </Button>
                  </div>
                </div>
              ))}
          </div>
        </Card>
      </div>
    </div>
  );
}

export default Admin;
