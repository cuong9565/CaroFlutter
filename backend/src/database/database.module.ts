import { Module } from '@nestjs/common';
import { neon } from '@neondatabase/serverless';
import { ConfigService } from '@nestjs/config';

@Module({
  providers: [
    {
      provide: 'POSTGRES_POOL',
      inject: [ConfigService],
      useFactory: (configService: ConfigService) => {
        const url = configService.get<string>('DATABASE_URL');
        if (!url) {
          throw new Error('DATABASE_URL is not defined');
        }
        return neon(url);
      },
    },
  ],
  exports: ['POSTGRES_POOL'],
})
export class DatabaseModule {}
