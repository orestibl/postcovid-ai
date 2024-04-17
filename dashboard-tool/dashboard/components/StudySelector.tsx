import React, { useEffect } from "react";
import MenuItem from "@mui/material/MenuItem";
import FormHelperText from "@mui/material/FormHelperText";
import FormControl from "@mui/material/FormControl";
import Select, { SelectChangeEvent } from "@mui/material/Select";
import { Study, UserToStudy } from "@/types/types";
import { useQuery } from "react-query";
import { getStudies } from "@/app/action";

type Props = {
  value: string;
  setValue: (value: string) => void;
};

function StudySelector({ value, setValue }: Props) {
  const useStudies = () => {
    return useQuery("study", async () => {
      const res = await getStudies();

      return res;
    });
  };

  const { data, isLoading, error, isSuccess, isRefetching } = useStudies();

  if (isLoading) return <div>Loading...</div>;

  if (error) return <div>Error loading studies</div>;

  const onChange = (event: SelectChangeEvent) => {
    setValue(event.target.value);
  };

  return (
    <FormControl>
      <Select value={value} onChange={onChange}>
        {data?.map((study: Study) => {
          return (
            <MenuItem key={study.id} value={study.id}>
              {study.name}
            </MenuItem>
          );
        })}
      </Select>
      <FormHelperText>Select a Study</FormHelperText>
    </FormControl>
  );
}

export default StudySelector;
