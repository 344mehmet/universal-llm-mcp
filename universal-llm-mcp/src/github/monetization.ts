/**
 * GitHub Sponsors Monetization Service
 * Ücretli kullanıcı yönetimi ve ödeme entegrasyonu
 */

export interface SponsorTier {
    id: string;
    name: string;
    priceUSD: number;
    features: string[];
    issuesPerMonth: number;
    priority: number;
}

export interface Sponsor {
    id: string;
    githubUsername: string;
    email: string;
    tier: SponsorTier;
    isActive: boolean;
    startDate: Date;
    issuesUsedThisMonth: number;
    totalIssuesSolved: number;
    totalPaid: number;
}

// Tier tanımları
export const SPONSOR_TIERS: Record<string, SponsorTier> = {
    free: {
        id: 'free',
        name: 'Free',
        priceUSD: 0,
        features: ['Temel issue analizi', 'Manuel PR inceleme'],
        issuesPerMonth: 5,
        priority: 0,
    },
    starter: {
        id: 'starter',
        name: 'Starter',
        priceUSD: 9,
        features: ['50 issue/ay', 'Otomatik PR oluşturma', 'Email bildirimler'],
        issuesPerMonth: 50,
        priority: 1,
    },
    pro: {
        id: 'pro',
        name: 'Pro',
        priceUSD: 29,
        features: ['200 issue/ay', 'Öncelikli işlem', 'Özel model erişimi', 'Slack entegrasyonu'],
        issuesPerMonth: 200,
        priority: 2,
    },
    enterprise: {
        id: 'enterprise',
        name: 'Enterprise',
        priceUSD: 99,
        features: ['Sınırsız issue', 'Özel agent', '7/24 destek', 'SLA garantisi'],
        issuesPerMonth: -1, // Sınırsız
        priority: 3,
    },
};

/**
 * Monetization Service
 */
export class MonetizationService {
    private sponsors: Map<string, Sponsor> = new Map();
    private ownerUsername: string;

    constructor(ownerUsername: string) {
        this.ownerUsername = ownerUsername;
    }

    /**
     * Sponsor kontrolü
     */
    isSponsor(githubUsername: string): boolean {
        if (githubUsername === this.ownerUsername) return true;
        return this.sponsors.has(githubUsername);
    }

    /**
     * Sponsor bilgisi al
     */
    getSponsor(githubUsername: string): Sponsor | null {
        if (githubUsername === this.ownerUsername) {
            return {
                id: 'owner',
                githubUsername: this.ownerUsername,
                email: '344mehmet@gmail.com',
                tier: { ...SPONSOR_TIERS.enterprise, name: 'Owner', priceUSD: 0 },
                isActive: true,
                startDate: new Date(0),
                issuesUsedThisMonth: 0,
                totalIssuesSolved: 0,
                totalPaid: 0,
            };
        }
        return this.sponsors.get(githubUsername) || null;
    }

    /**
     * Kullanım hakkı kontrolü
     */
    canUseService(githubUsername: string): { allowed: boolean; reason?: string } {
        const sponsor = this.getSponsor(githubUsername);

        if (!sponsor) {
            return { allowed: false, reason: 'Sponsor değilsiniz. GitHub Sponsors üzerinden abone olun.' };
        }

        if (!sponsor.isActive) {
            return { allowed: false, reason: 'Aboneliğiniz aktif değil.' };
        }

        // Sınırsız kullanıcılar
        if (sponsor.tier.issuesPerMonth === -1) {
            return { allowed: true };
        }

        // Limit kontrolü
        if (sponsor.issuesUsedThisMonth >= sponsor.tier.issuesPerMonth) {
            return {
                allowed: false,
                reason: `Aylık limitinize (${sponsor.tier.issuesPerMonth}) ulaştınız. Tier yükseltin.`
            };
        }

        return { allowed: true };
    }

    /**
     * Kullanım kaydet
     */
    recordUsage(githubUsername: string): boolean {
        const sponsor = this.sponsors.get(githubUsername);
        if (!sponsor) return false;

        sponsor.issuesUsedThisMonth++;
        sponsor.totalIssuesSolved++;
        return true;
    }

    /**
     * Aylık reset
     */
    monthlyReset(): void {
        for (const sponsor of this.sponsors.values()) {
            sponsor.issuesUsedThisMonth = 0;
        }
        console.log('📅 Aylık kullanım limitleri sıfırlandı');
    }

    /**
     * Sponsor ekle (webhook'tan)
     */
    addSponsor(githubUsername: string, email: string, tierId: string): Sponsor {
        const tier = SPONSOR_TIERS[tierId] || SPONSOR_TIERS.free;

        const sponsor: Sponsor = {
            id: `sponsor_${Date.now()}`,
            githubUsername,
            email,
            tier,
            isActive: true,
            startDate: new Date(),
            issuesUsedThisMonth: 0,
            totalIssuesSolved: 0,
            totalPaid: tier.priceUSD,
        };

        this.sponsors.set(githubUsername, sponsor);
        console.log(`🎉 Yeni sponsor: ${githubUsername} (${tier.name})`);

        return sponsor;
    }

    /**
     * Sponsor çıkar
     */
    removeSponsor(githubUsername: string): boolean {
        return this.sponsors.delete(githubUsername);
    }

    /**
     * Fiyatlandırma bilgisi
     */
    getPricingInfo(): SponsorTier[] {
        return Object.values(SPONSOR_TIERS);
    }

    /**
     * İstatistikler
     */
    getStats(): { totalSponsors: number; monthlyRevenue: number; totalIssuesSolved: number } {
        let monthlyRevenue = 0;
        let totalIssuesSolved = 0;

        for (const sponsor of this.sponsors.values()) {
            if (sponsor.isActive) {
                monthlyRevenue += sponsor.tier.priceUSD;
            }
            totalIssuesSolved += sponsor.totalIssuesSolved;
        }

        return {
            totalSponsors: this.sponsors.size,
            monthlyRevenue,
            totalIssuesSolved,
        };
    }
}

/**
 * GitHub Sponsors Webhook Handler
 */
export function handleSponsorWebhook(
    service: MonetizationService,
    event: string,
    payload: any
): void {
    switch (event) {
        case 'sponsorship.created':
            const { sponsor, tier } = payload.sponsorship;
            service.addSponsor(
                sponsor.login,
                sponsor.email || `${sponsor.login}@github.com`,
                tier.name.toLowerCase()
            );
            break;

        case 'sponsorship.cancelled':
            const cancelledSponsor = service.getSponsor(payload.sponsorship.sponsor.login);
            if (cancelledSponsor) {
                cancelledSponsor.isActive = false;
            }
            break;

        case 'sponsorship.tier_changed':
            const existingSponsor = service.getSponsor(payload.sponsorship.sponsor.login);
            if (existingSponsor) {
                const newTier = SPONSOR_TIERS[payload.sponsorship.tier.name.toLowerCase()];
                if (newTier) {
                    existingSponsor.tier = newTier;
                }
            }
            break;
    }
}
