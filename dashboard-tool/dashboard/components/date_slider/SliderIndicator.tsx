import * as React from 'react';
import Slider from '@mui/material/Slider';
import {useDateSliderStore} from '@/store/store';

type Props = {
    steps: number,
}

export default function SliderIndicator({steps}: Props) {

  const updateCurrentDate = useDateSliderStore.getState().updateCurrentDate;
  const dateLeft = useDateSliderStore.getState().dateLeft;  

  return (
        <div className='w-48'>
        <Slider
        aria-label="Temperature"
        defaultValue={1}
        valueLabelDisplay="off"
        step={1}
        marks
        min={1}
        max={steps}
        onChange={(e, value) => {
            if (typeof value === 'number' && dateLeft) {
              updateCurrentDate(dateLeft.add(value, 'day'));
            }
          }}
        />
        </div>

  );
}