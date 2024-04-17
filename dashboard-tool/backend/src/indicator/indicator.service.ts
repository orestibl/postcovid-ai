import { Injectable } from '@nestjs/common';
import { CreateIndicatorDto } from './dto/create-indicator.dto';
import { UpdateIndicatorDto } from './dto/update-indicator.dto';
import { InjectRepository } from '@nestjs/typeorm';
import { Indicator } from './entities/indicator.entity';
import { Between, Repository } from 'typeorm';
import { IndicatorQuery } from '../types/types';
import { CriterionType } from '../lib/utils';
import { Filter } from '../filter/entities/filter.entity';
import * as dayjs from 'dayjs';
import { fakerES as faker } from '@faker-js/faker';
import { ParticipantService } from 'src/participant/participant.service';

@Injectable()
export class IndicatorService {
  constructor(
    @InjectRepository(Indicator, 'indicators')
    private indicatorRepository: Repository<Indicator>,
    private participantService: ParticipantService,
  ) {}

  create(createIndicatorDto: CreateIndicatorDto) {
    return this.indicatorRepository.create(createIndicatorDto);
  }

  async findAll(query: IndicatorQuery) {
    if (query.filters === undefined) return [];

    const criterion = [];

    for (const filter of query.filters) {
      const criteria = {};
      for (const criterionDetail of filter.filterToCriterion) {
        const name =
          criterionDetail.criterion.name !== 'age'
            ? criterionDetail.criterion.name
            : 'birth_date';

        const min =
          criterionDetail.criterion.name === 'age'
            ? dayjs()
                .subtract(criterionDetail.higher_value, 'year')
                .format('YYYY-MM-DD')
            : criterionDetail.lower_value;

        const max =
          criterionDetail.criterion.name === 'age'
            ? dayjs().format('YYYY-MM-DD')
            : criterionDetail.higher_value;

        criteria[name] =
          criterionDetail.criterion.nature === CriterionType.RANGE
            ? Between(min, max)
            : criterionDetail.value;
      }
      criterion.push(criteria);
    }

    const querys = criterion.map((criterion) => {
      return this.indicatorRepository.find({
        relations: ['indicatorName', 'participant'],
        where: {
          study: query.study,
          participant: { ...criterion },
        },
      });
    });

    const res = await Promise.all(querys);

    return this.getDailyValues(res, query.filters);
  }

  private getDailyValues(res: Indicator[][], filters: Filter[]) {
    const indResult = [];

    let ind = 0;

    const filt = [...filters, { id: 0, name: 'All', color: '#009688' }];

    for (const indicators of res) {
      let lowerDate = new Date(
        Math.min(
          ...indicators.map((indicator) => new Date(indicator.date).getTime()),
        ),
      );
      let higherDate = new Date(
        Math.max(
          ...indicators.map((indicator) => new Date(indicator.date).getTime()),
        ),
      );

      const categories = new Map<string, number>();
      const categoryValues = new Map<string, number>();
      const categoryAverages = new Map<string, number>();

      const dayValues = [];

      for (
        let date = new Date(lowerDate);
        date <= higherDate;
        date.setDate(date.getDate() + 1)
      ) {
        //take the indicators for the current day
        const dailyIndicators = indicators.filter((indicator) => {
          return new Date(indicator.date).getTime() === date.getTime();
        });

        dailyIndicators.forEach((indicator) => {
          const name = indicator.indicatorName.name;

          if (categories.has(name)) {
            categories.set(name, categories.get(name) + 1);
            categoryValues.set(
              name,
              categoryValues.get(name) + indicator.value,
            );
          } else {
            categories.set(name, 1);
            categoryValues.set(name, indicator.value);
          }
        });

        for (const [key, value] of categoryValues.entries())
          categoryAverages.set(key, value / categories.get(key));

        const categoryAveragesObject = Object.fromEntries(categoryAverages);
        dayValues.push({
          ...categoryAveragesObject,
          date: date.toISOString(),
          color: filt[ind].color,
        });
      }
      ind++;
      indResult.push(dayValues);
    }

    return indResult;
  }

  findOne(id: number) {
    return this.indicatorRepository.findOne({ where: { id } });
  }

  update(id: number, updateIndicatorDto: UpdateIndicatorDto) {
    return this.indicatorRepository.update(id, updateIndicatorDto);
  }

  remove(id: number) {
    return this.indicatorRepository.delete(id);
  }

  async seed() {
    const studies = {
      H39eC: [
        'AMdzA',
        'ASTAT',
        'AWtpE',
        'AYTpR',
        'AZpyK',
        'AsSmH',
        'AtqXk',
        'AwgNc',
        'AyEMM',
        'BBAgT',
        'BNxKr',
        'BWfTm',
        'BXaLT',
        'BYkke',
        'BaJfQ',
        'BamPP',
        'BdjFa',
        'BktHR',
        'BmhcR',
        'BpmYq',
        'BqTss',
        'BqfmY',
        'BwWaz',
        'CJcGQ',
        'CbKNG',
        'CcbDn',
        'CjznG',
        'CmYHc',
        'CtRWH',
        'CxnMe',
        'CyDzk',
        'CyrTC',
        'DCPqP',
        'DHgan',
        'DRGBk',
        'DWzBT',
        'DYJdj',
        'DYPRj',
        'DgbeZ',
        'Dnmss',
        'DtrnX',
        'DxCYC',
        'DxqCG',
        'ECGpH',
        'ECXmx',
        'EJxFx',
        'ERZfK',
        'EWmRP',
        'EdKkL',
        'EdYYC',
        'EfKDL',
        'EkMQM',
        'EqcqL',
        'ErqbN',
        'EswHG',
        'EtYXS',
        'EwMdx',
        'FAnKE',
        'FBJrR',
        'FEpwR',
        'FGnnm',
        'FLHRB',
        'FNYAP',
        'FPeSN',
        'FSRGS',
        'FThba',
        'FYqbw',
        'FcKXA',
        'FhWgg',
        'FjQrE',
        'FqxQM',
        'GBCbL',
        'GCFfZ',
        'GEKPx',
        'GGXLd',
        'GKXQg',
        'GKgpP',
        'GLqxK',
        'GMZLy',
        'GWnLj',
        'GaZnT',
        'GabbS',
        'GadYg',
        'GdnaZ',
        'GgCzr',
        'GjWRy',
        'GmCRH',
        'GysBE',
        'HAhqp',
        'HHLFK',
        'HMAfk',
        'HRtcB',
        'HYBpb',
        'HYYRN',
        'HZeKY',
        'HfpxJ',
        'HjMpA',
        'HtFPY',
        'HyfKb',
        'HzYhk',
        'JCWAa',
        'JMGEX',
        'JQtbn',
        'JTdxD',
        'JWAgG',
        'JXBZn',
        'JdCGP',
        'JfpJK',
        'Jgjbb',
        'Jhejj',
        'Jnryq',
        'JrFmM',
        'Jykay',
        'KAHSy',
        'KDKNc',
        'KEmmk',
        'KFszN',
        'KWwRS',
        'KXRap',
        'KcTxF',
        'KfgNQ',
        'KfxXL',
        'KgkBr',
        'KhXxy',
        'Khetq',
        'KmrBB',
        'KnmhS',
        'KyEWd',
        'KyKyF',
        'KyWqq',
        'KzXLM',
        'LKSsK',
        'LSnqJ',
        'LWMyC',
        'LWyyX',
        'LXPQw',
        'LZLNr',
        'LkbKm',
        'LmhFB',
        'Lmkpk',
        'LyLqC',
        'MEWeL',
        'MFbDh',
        'MRLrj',
        'MTcLQ',
        'MckZj',
        'MdasG',
        'MefgD',
        'MfDcH',
        'MfXsG',
        'MhMDQ',
        'MmDND',
        'MzTyE',
        'NEMKS',
        'NGaBr',
        'NMnhF',
        'NZWLR',
        'NcWPQ',
        'NdxyZ',
        'NgPDb',
        'NrSbn',
        'NwWPc',
        'Nxdhf',
        'NxrmR',
        'NzDQh',
        'NzsYM',
        'PGaqa',
        'PMaHg',
        'PgKBW',
        'PkytJ',
        'PnAAr',
        'PpXbD',
        'PsYay',
        'PyrQn',
        'QCHGW',
        'QCJJg',
        'QJHrZ',
        'QJzJg',
        'QZLFh',
        'Qjcht',
        'QkCte',
        'QkcpS',
        'QpwTr',
        'QxSGA',
        'QzdBX',
        'QzmTe',
        'RCfZG',
        'RFcrc',
        'RGFQa',
        'RNRLS',
        'RPfea',
        'RRrEa',
        'Raggp',
        'RamMn',
        'RcXNP',
        'RccCf',
        'RefrL',
        'RfHyc',
        'RgRXr',
        'RkWdT',
        'RpGwr',
        'Rtref',
        'RwbZF',
        'aNbmR',
        'aQSjJ',
        'aQYqf',
        'aRmLM',
        'aZMJT',
        'aZNDn',
        'aprHB',
        'arcMF',
        'arqHW',
        'awNKr',
        'bDwPb',
        'bFWGP',
        'bLGmQ',
        'bQbmH',
        'bWGNp',
        'bYgKC',
        'bZemq',
        'baPrB',
        'bazye',
        'beKNQ',
        'bhDSM',
        'bjRmR',
        'bsFpb',
        'bsrKP',
        'bxKaL',
        'cAwNH',
        'cCKTA',
        'cDnEq',
        'cLqTd',
        'cPpEj',
        'cSdGG',
        'cTTrG',
        'cYLYn',
        'cawJQ',
        'cddBw',
        'cghLa',
        'cpKgP',
        'cyeHZ',
        'czJSr',
        'dAzgQ',
        'dCjHA',
        'dDZFN',
        'dEZtE',
        'dEkJd',
        'dFCpP',
        'dFnmL',
        'dGfJA',
        'dKLGx',
        'dYrZD',
        'djfRz',
        'eFLdp',
        'eFakt',
        'eKxXm',
        'eZbHd',
        'ebsRf',
        'ecDae',
        'ecHGQ',
        'edTdS',
        'ehZMg',
        'ehdwj',
        'emjgN',
        'enZyn',
        'eqABn',
        'fBCGr',
        'fLCnp',
        'fTZKk',
        'fYbJS',
        'faEJW',
        'gBPSZ',
        'gFyTt',
        'gJmNp',
        'gLhzW',
        'gPxTC',
        'gWqTs',
        'gbqqA',
        'gcFDW',
        'ghjBF',
        'gmNyJ',
        'gtzht',
        'gzyrj',
        'hAYSy',
        'hCafc',
        'hEssC',
        'hNDpZ',
        'hQSFN',
        'hSxyr',
        'hWaSy',
        'hZgBJ',
        'hpYpc',
        'hpaQa',
        'hqPrj',
        'hrTxd',
        'htLnT',
        'jEqQS',
        'jGZDP',
        'jJPRn',
        'jMjqJ',
        'jSKyK',
        'jSRan',
        'jbRZR',
        'jbjJZ',
        'jcRGd',
        'jdRyF',
        'jdcah',
        'jeLBE',
        'jjBjT',
        'kABaA',
        'kAGtG',
        'kDeMe',
        'kFCPz',
        'kKfxy',
        'kMEdS',
        'kMsNe',
        'kNPTy',
        'kWFXN',
        'kebJK',
        'kfMpg',
        'kjTds',
        'kjhWD',
        'kmFjT',
        'kmPMw',
        'knqtW',
        'kpLWC',
        'mASfj',
        'mDXkm',
        'mEeEE',
        'mEnTt',
        'mHEnd',
        'mLsHP',
        'mWJbQ',
        'mXtqQ',
        'mZkqT',
        'mcmtw',
        'mmmZZ',
        'mmqEj',
        'mwNny',
        'mySfN',
        'nAqKq',
        'nCrbS',
        'nKkSb',
        'nMcXM',
        'naySk',
        'nbxaE',
        'nmQkh',
        'nnfEB',
        'npDJT',
        'nxkxr',
        'pBMee',
        'pFFJe',
        'pGfpf',
        'pHKbf',
        'pHsfB',
        'pJCFT',
        'pJsMX',
        'pMzyc',
        'pRJXC',
        'pWnhb',
        'paPRX',
        'pcFDK',
        'pcRTD',
        'pfAXG',
        'pfcDE',
        'pgqKK',
        'pkhTc',
        'pmyEY',
        'pwMay',
        'pwrHf',
        'pyekS',
        'qCzhC',
        'qKKKN',
        'qSBxN',
        'qWRpy',
        'qWWQH',
        'qXYck',
        'qagNn',
        'qkMdR',
        'qmPjG',
        'qxxRA',
        'rDzfQ',
        'rGtaN',
        'rHXJh',
        'rPDMX',
        'rPzxY',
        'raCsm',
        'rbYQC',
        'rgbxB',
        'rmWtX',
        'rsgrE',
        'DwmBF',
        'JytXS',
        'KYzTC',
        'PpyDx',
      ],
      aFeH8: [
        'A3FNz',
        'A3XAe',
        'A3XNv',
        'Ac3N5',
        'Ag5za',
        'B9kLj',
        'Be8DH',
        'FtVE5',
        'Gxtq3',
        'H7d5E',
        'HXW9n',
        'Hj2SV',
        'JZ7Zt',
        'KjR6Q',
        'Mp54E',
        'MtHB7',
        'NpT7s',
        'Nu2yh',
        'NuU8Y',
        'P7jQ4',
        'PDm53',
        'PznH7',
        'Q6seK',
        'Qg5YV',
        'QuL2N',
        'Qut6y',
        'Qx7BF',
        'RYKh6',
        'RtC73',
        'S5HpG',
        'U4Ywp',
        'UGx4S',
        'UyV8R',
        'VCwD6',
        'VjWA7',
        'W8wnz',
        'WhZB9',
        'WupP8',
        'X2j6P',
        'YT9gU',
        'a8yBw',
        'aS6pp',
        'aU5A8',
        'ak7Nj',
        'ay4Ya',
        'bLV4y',
        'bSFa8',
        'bSN4s',
        'bs5WY',
        'bxNq7',
        'cCyB2',
        'cb7ZF',
        'cbrW7',
        'd82Xy',
        'dRT9L',
        'fJQy3',
        'fS99N',
        'g5SRT',
        'gx3V9',
        'jbNM5',
        'jhh3A',
        'k3MwM',
        'k5SxB',
        'kCwD9',
        'kYm4j',
        'ker7N',
        'kn4Kq',
        'kv4Ee',
        'kz5Bk',
        'm4V5e',
        'm5XG9',
        'mTnH2',
        'nDwk9',
        'nu8Bm',
        'pV2sm',
        'q8Rau',
        'qURb2',
        'r3gCK',
        'rSW8r',
        's4Q9Z',
        's5Kra',
        's97L9',
        'svVj9',
        't8dEA',
        'tDX2u',
        'tSse5',
        'uDG5v',
        'uLF2q',
        'uQf2z',
        'v57Xy',
        'vb5Pj',
        'vsa4T',
        'w7xMB',
        'w9dVK',
        'x8C4P',
        'yS8M2',
        'zKaN5',
        'zP599',
        'zkJw7',
        'zv3PG',
        'DesV4',
        'XfAg9',
        'hhk8Y',
      ],
    };

    try {
      for (const key in studies) {
        const study = studies[key];
        // Iterate over each participant ID in the current array

        for (let i = 0; i < 4; i++) {
          let dailyCount = 0;
          for (
            let date = dayjs('2023-08-15');
            date.isBefore(dayjs('2023-10-16'));
            date = date.add(1, 'day')
          ) {
            dailyCount++;

            for (const participantId of study) {
              const participant =
                await this.participantService.findOne(participantId);

              // let min = participant.salary < 30000 ? 30 : 0;
              // let max = participant.salary < 30000 ? 100 : 70;

              let min = participant.gender === 'male' ? 10 : 30;
              let max = participant.gender === 'male' ? 30 : 50;

              min = dayjs(participant.birth_date).isAfter('1995-01-01', 'year')
                ? min
                : min + 20;
              max = dayjs(participant.birth_date).isAfter('1995-01-01', 'year')
                ? max
                : max + 20;

              const randomBoolean = Math.random() < 0.5;

              min = randomBoolean ? (min + dailyCount) % 100 : min - 30;
              max = randomBoolean ? (max + dailyCount) % 100 : max - 30;

              //Random boolean
              min = Math.random() < 0.5 ? min : max;

              if (min < 0) min = 0;

              const ind = this.indicatorRepository.create({
                value: min,
                date: date.toDate(),
                study: { id: key },
                participant: { id: participantId },
                indicatorName: { id: i + 1 },
              });

              await this.indicatorRepository.save(ind);
            }
          }
          // Your logic here
        }
      }
    } catch (e) {
      console.log(e);
    }

    return 'Seeded participants';
  }
}
