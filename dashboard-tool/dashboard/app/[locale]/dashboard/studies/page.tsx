'use client';
import React from "react";
import { getStudies } from "@/app/action";
import { useQuery } from "react-query";
import { Study } from "@/types/types";

const useStudies = () => {
  return useQuery("study", async () => {
    const res = await getStudies();

    return res;
  });}

  export default function Studies() {

  const { data, isLoading, error, isSuccess, isRefetching } = useStudies();

  return (
    <div className="w-full h-full flex justify-center items-start">
      {isLoading && <div>Loading...</div>}
      {isSuccess && (
        <div className="w-[50%] mt-14">
          {data.map((study: Study) => (
            <div className="flex items-center justify-center" key={study.id}>
              <h3 className="mr-4">{study.name}</h3>
              <p>{study.description}</p>
            </div>
          ))}
        </div>
      )}
    </div>
  );
}
